# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}

include:
  - {{ sls_config_file }}

{% if splunkforwarder['boottype'] == 'systemd' %}
splunkforwarder-systemd-running-service-running:
  service.running:
    - name: SplunkForwarder
    - enable: True
    - watch:
      - sls: {{ sls_config_file }}
{% elif splunkforwarder['boottype'] == 'initd' %}
splunkforwarder-initd-running-service-running:
  service.running:
    - name: splunk
    - enable: True
{% if salt['grains.get']('init') != 'service'%}
    - provider: service
{% endif %}
    - watch:
      - sls: {{ sls_config_file }}
{% endif %}