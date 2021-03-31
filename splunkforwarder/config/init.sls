# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}

include:
  - .file
{% if splunkforwarder['createlocaluser'] != 'false' %}
  - .user
{% endif %}
{% if splunkforwarder['configcerts'] != 'false' %}
  - .certs
{% endif %}