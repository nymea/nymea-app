#include <QtCore/QtGlobal>

#if defined(LIBNYMEA_COMMON)
#  define LIBNYMEA_COMMON_EXPORT Q_DECL_EXPORT
#else
#  define LIBNYMEA_COMMON_EXPORT Q_DECL_IMPORT
#endif
