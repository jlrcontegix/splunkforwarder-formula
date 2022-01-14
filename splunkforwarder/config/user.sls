# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set make_usergroup = splunkforwarder.user == splunkforwarder.group %}

{#- for simplicity, combine into a singular list #}
{%- if not make_usergroup %}
{% do splunkforwarder.additionalgroups.append(splunkforwarder.group) %}
{% endif %}

splunkforwarder_user:
  user.present:
    - name: {{ splunkforwarder.user }}
    - home: /opt/splunkforwarder
    - usergroup: {{ make_usergroup }}
{% if splunkforwarder.additionalgroups %}
    - groups:
      {% for group in splunkforwarder.additionalgroups %}
      - {{ group }}
      {% endfor %}
{% endif %}
