#ifndef REPOSITORIES_H
#define REPOSITORIES_H

#include <QAbstractListModel>

class Repository;

class Repositories : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId,
        RoleDisplayName,
        RoleEnabled
    };
    Q_ENUM(Roles)

    explicit Repositories(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE Repository* get(int index) const;
    Q_INVOKABLE Repository* getRepository(const QString &id) const;

    void addRepository(Repository* repository);
    void removeRepository(const QString &repositoryId);
    void clear();

signals:
    void countChanged();

private:
    QList<Repository*> m_list;
};

#endif // REPOSITORIES_H
