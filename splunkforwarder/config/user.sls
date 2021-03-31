# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

splunkforwarder_user:
  user.present:
    - name: {{ splunkforwarder.user }}
    - home: /opt/splunkforwarder
    - usergroup: {{ splunkforwarder.group }}
    - groups:
      - {{ splunkforwarder.group }}
      {% for group in {{ splunkforwarder.additionalgroups }} -%}
      - {{ group }}
      {%- endfor %}