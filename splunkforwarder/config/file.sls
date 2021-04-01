# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

{% if splunkforwarder['boottype'] == 'initd' %}
splunkforwarder-systemd-dead:
  service.dead:
    - name: SplunkForwarder

splunkforwarder-remove-systemd-file:
  file.absent:
    - name: /etc/systemd/system/SplunkForwarder.service

splunkforwarder-initd-permissions:
  file.directory:
    - name: /opt/splunkforwarder
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - recurse:
      - user
      - group

splunkforwarder-configure-initd:
  cmd.run:
    - name: /opt/splunkforwarder/bin/splunk enable boot-start -user {{ splunkforwarder.user }} --accept-license --answer-yes --no-prompt
    - onlyif: test -z "$(ls -A /etc/rc.d/init.d/splunk)"
    - require:
      - sls: {{ sls_package_install }}
{% endif %}

{% if splunkforwarder['boottype'] == 'systemd' %}
splunkforwarder-initd-dead:
  service.dead:
    - name: splunk

splunkforwarder-remove-initd-file:
  file.absent:
    - name: /etc/rc.d/init.d/splunk

splunkforwarder-systemd-permissions:
  file.directory:
    - name: /opt/splunkforwarder
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - recurse:
      - user
      - group

splunkforwarder-configure-systemd:
  cmd.run:
    - name: /opt/splunkforwarder/bin/splunk enable boot-start -user {{ splunkforwarder.user }} -systemd-managed 1 --accept-license --answer-yes --no-prompt
    - onlyif: test -z "$(ls -A /etc/systemd/system/SplunkForwarder.service)"
    - require:
      - sls: {{ sls_package_install }}
{% endif %}

{% if splunkforwarder.deploymentserver['enabled'] == 'true' %}
splunkforwarder-deploymentclient-file-file-managed:
  file.managed:
    - name: /opt/splunkforwarder/etc/system/local/deploymentclient.conf
    - source: {{ files_switch(['deploymentclient.tmpl.jinja'],
                              lookup='splunkforwarder-deploymentclient-file-file-managed'
                 )
              }}
    - mode: 644
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        splunkforwarder: {{ splunkforwarder | json }}
{% endif %}

{% if splunkforwarder.peernodes['enabled'] == 'true' %}
splunkforwarder-peers-file-file-managed:
  file.managed:
    - name: /opt/splunkforwarder/etc/system/local/outputs.conf
    - source: {{ files_switch(['peeroutputs.tmpl.jinja'],
                              lookup='splunkforwarder-peers-file-file-managed'
                 )
              }}
    - mode: 644
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        splunkforwarder: {{ splunkforwarder | json }}
{% endif %}

{% if splunkforwarder.indexer_discovery['enabled'] == 'true' %}
splunkforwarder-indexerdiscovery-file-file-managed:
  file.managed:
    - name: /opt/splunkforwarder/etc/system/local/outputs.conf
    - source: {{ files_switch(['discoveryoutputs.tmpl.jinja'],
                              lookup='splunkforwarder-indexerdiscovery-file-file-managed'
                 )
              }}
    - mode: 644
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        splunkforwarder: {{ splunkforwarder | json }}
{% endif %}