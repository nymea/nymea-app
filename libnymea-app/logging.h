#ifndef LOGGING_H
#define LOGGING_H

#include <QLoggingCategory>

QStringList& nymeaLoggingCategories();

#define NYMEA_LOGGING_CATEGORY(name, string) \
    class NymeaLoggingCategory##name: public QLoggingCategory { \
    public: \
    NymeaLoggingCategory##name(): QLoggingCategory(string) { nymeaLoggingCategories().append(string); } \
    }; \
    static NymeaLoggingCategory##name s_##name; \
    const QLoggingCategory &name() \
    { \
        return s_##name; \
    } \


#endif // LOGGING_H
