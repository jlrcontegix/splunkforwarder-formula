# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set make_usergroup = splunkforwarder.user == splunkforwarder.group %}
{%- set pre_v3001 = salt['salt_version.less_than']("Sodium") %}

{#- for simplicity, combine into a singular list #}
{%- if not make_usergroup or pre_v3001 %}
{% do splunkforwarder.additionalgroups.append(splunkforwarder.group) %}
{% endif %}

splunkforwarder_user:
{#- the usergroup bool isn't added until 3001 (a.k.a Sodium).
    Manually create the group #}
{%- if pre_v3001 %}
  group.present:
    - name: {{ splunkforwarder.group }}
{% endif %}

  user.present:
    - name: {{ splunkforwarder.user }}
    - home: /opt/splunkforwarder
{%- if not pre_v3001 %}
    - usergroup: {{ make_usergroup }}
{% endif %}
{% if splunkforwarder.additionalgroups %}
    - groups:
      {% for group in splunkforwarder.additionalgroups %}
      - {{ group }}
      {% endfor %}
{% endif %}
