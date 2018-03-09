TEMPLATE=subdirs

SUBDIRS = libnymea-common mea
libnymea-common.subdir = libnymea-common
mea.subdir = mea

mea.depends = libnymea-common
