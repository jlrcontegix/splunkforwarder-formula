# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as splunkforwarder with context %}

{% if splunkforwarder.pkg['type'] == 'url' %}
splunkforwarder-rpmurlpackage-install-pkg-installed:
  pkg.installed:
    - sources:
      - splunkforwarder: {{ splunkforwarder.pkg.url }}
{% endif %}

{% if splunkforwarder.pkg['type'] == 'pkg' %}
splunkforwarder-package-install-pkg-installed:
  pkg.installed:
    - name: {{ splunkforwarder.pkg.name }}
    - version: {{ splunkforwarder.pkg.version }}
{% endif %}

{% if splunkforwarder.pkg['type'] == 'tar' %}
splunkforwarder-tar-dependency:
  pkg.installed:
    - name: tar

splunkforwarder-tar-installed:
  archive.extracted:
    - name: /opt
    - source: {{ splunkforwarder.pkg.tarurl }}
    - user: {{ splunkforwarder.user }}
    - group: {{ splunkforwarder.group }}
    - skip_verify: True
    - require:
      - pkg: splunkforwarder-tar-dependency
{% endif %}