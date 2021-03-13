#include "logging.h"

QStringList& nymeaLoggingCategories() {
    static QStringList _nymeaLoggingCategories;
    return _nymeaLoggingCategories;
}
