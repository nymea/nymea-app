include(guh-control.pri)

TEMPLATE=subdirs

SUBDIRS += backend libguh-common
backend.depends = libguh-common
