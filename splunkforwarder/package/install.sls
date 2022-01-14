# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_user = tplroot ~ '.config.user' %}
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
{#- we must create the user before we can assign ownership via tar install #}
{% if splunkforwarder['createlocaluser'] | to_bool %}
include:
  - {{ sls_config_user }}

splunkforwarder-tar-opt-splunkforwarder:
  file.directory:
    - name: /opt/splunkforwarder
    - unless:
      - stat /opt/splunkforwarder
{% endif %}

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
    - unless:
      - /opt/splunkforwarder/bin/splunk --version | grep -q {{ splunkforwarder.pkg.version }}
    - require:
      - pkg: splunkforwarder-tar-dependency
{% if splunkforwarder['createlocaluser'] | to_bool %}
      - sls: {{ sls_config_user }}
{% endif %}
{% endif %}


