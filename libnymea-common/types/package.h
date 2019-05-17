#ifndef PACKAGE_H
#define PACKAGE_H

#include <QObject>

class Package : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QString installedVersion READ installedVersion NOTIFY installedVersionChanged)
    Q_PROPERTY(QString candidateVersion READ candidateVersion NOTIFY candidateVersionChanged)
    Q_PROPERTY(QString changelog READ changelog NOTIFY changelogChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateAvailableChanged)
    Q_PROPERTY(bool rollbackAvailable READ rollbackAvailable NOTIFY rollbackAvailableChanged)
    Q_PROPERTY(bool canRemove READ canRemove NOTIFY canRemoveChanged)

public:
    explicit Package(const QString &id, const QString &displayName, QObject *parent = nullptr);

    QString id() const;
    QString displayName() const;

    QString installedVersion() const;
    void setInstalledVersion(const QString &installedVersion);

    QString candidateVersion() const;
    void setCandidateVersion(const QString &candidateVersion);

    QString changelog() const;
    void setChangelog(const QString &changelog);

    bool updateAvailable() const;
    void setUpdateAvailable(bool updateAvailable);

    bool rollbackAvailable() const;
    void setRollbackAvailable(bool rollbackAvailable);

    bool canRemove() const;
    void setCanRemove(bool canRemove);

signals:
    void installedVersionChanged();
    void candidateVersionChanged();
    void changelogChanged();
    void updateAvailableChanged();
    void rollbackAvailableChanged();
    void canRemoveChanged();

private:
    QString m_id;
    QString m_displayName;
    QString m_installedVersion;
    QString m_candidateVersion;
    QString m_changelog;
    bool m_updateAvailable = false;
    bool m_rollbackAvailable = false;
    bool m_canRemove = false;
};

#endif // PACKAGE_H
