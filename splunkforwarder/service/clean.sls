# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}

splunkforwarder-service-clean-service-dead:
  service.dead:
    - name: {{ splunkforwarder.service.name }}
    - enable: False
