TEMPLATE=subdirs

SUBDIRS += libguh-common guh-control
libguh-common.subdir = libguh-common
guh-control.subdir = guh-control

guh-control.depends = libguh-common
