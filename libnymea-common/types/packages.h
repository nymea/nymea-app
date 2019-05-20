#ifndef PACKAGES_H
#define PACKAGES_H

#include <QAbstractListModel>

class Package;

class Packages: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId,
        RoleDisplayName,
        RoleSummary,
        RoleInstalledVersion,
        RoleCandidateVersion,
        RoleChangelog,
        RoleUpdateAvailable,
        RoleRollbackAvailable
    };
    Q_ENUM(Roles)

    explicit Packages(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addPackage(Package *package);
    void removePackage(const QString &packageId);

    Q_INVOKABLE Package* get(int index) const;
    Q_INVOKABLE Package* getPackage(const QString &packageId);

    void clear();

signals:
    void countChanged();

private:
    QList<Package*> m_list;
};

#endif // PACKAGES_H
