#include "privacypolicyhelper.h"

#include <QDir>
#include <QFile>
#include <QtDebug>
#include <QSettings>
#include <QCoreApplication>
#include <QLoggingCategory>

#include "platformhelper.h"

Q_DECLARE_LOGGING_CATEGORY(dcApplication)

PrivacyPolicyHelper::PrivacyPolicyHelper(QObject *parent) : QObject(parent)
{
    QDir dir(QString(":/privacypolicy/"));
    foreach (const QString &versionString, dir.entryList(QDir::NoDotAndDotDot | QDir::Dirs)) {
        bool ok;
        int version = versionString.toInt(&ok);
        if (ok && version > m_version) {
            m_version = version;
        }
    }
    if (m_version < 0) {
        qCWarning(dcApplication()) << "Privacy policy directory not found. :/privacypolicy/<version>/ expected.";
        return;
    }

    qCDebug(dcApplication()) << "Using privacy policy version" << m_version;
}

QObject* PrivacyPolicyHelper::qmlProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    static PrivacyPolicyHelper* qmlInstance = nullptr;
    if (!qmlInstance) {
        qmlInstance = new PrivacyPolicyHelper();
    }
    return qmlInstance;
}

int PrivacyPolicyHelper::version() const
{
    return m_version;
}

QString PrivacyPolicyHelper::text() const
{
    QFile f(findFile());
    if (!f.open(QFile::ReadOnly)) {
        qWarning() << "Cannot open privacy policy file for reading:" << f.fileName();
        return QString();
    }
    return f.readAll();
}

QString PrivacyPolicyHelper::findFile() const
{
    QString privacyPolicyFile = QString(":/privacypolicy/%1/privacypolicy-%2.md")
            .arg(m_version);
    QStringList languages = {
        QLocale().name(),
        QLocale().name().split('_').at(0),
        "en_US"
    };
    foreach (const QString &lang, languages) {
        qCDebug(dcApplication) << "Trying Privacy policy at" << privacyPolicyFile.arg(lang);
        if (QFile::exists(privacyPolicyFile.arg(lang))) {
            return privacyPolicyFile.arg(lang);
        }
    }
    return QString();
}
