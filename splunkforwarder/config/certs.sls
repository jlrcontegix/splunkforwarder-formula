# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

/opt/splunkforwarder/etc:
  file.directory:
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - mode: 755
    - makedirs: True
    - require:
      - user: {{ splunkforwarder.user }}

/opt/splunkforwarder/etc/certs:
  file.directory:
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - mode: 500
    - makedirs: True
    - require:
      - file: /opt/splunkforwarder/etc

{% for filename, config in salt['pillar.get']('splunkforwarder:certs', {}).items() %}

/opt/splunkforwarder/etc/certs/{{ filename }}:
  file.managed:
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.user }}
    - mode: {{ config.get('mode', 400) }}
    - contents_pillar: splunkforwarder:certs:{{ filename }}:content
    - require:
      - file: /opt/splunkforwarder/etc/certs
      - user: {{ splunkforwarder.user }}

{% endfor %}