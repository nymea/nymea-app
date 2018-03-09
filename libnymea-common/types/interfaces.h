#ifndef INTERFACES_H
#define INTERFACES_H

#include <QAbstractListModel>

class Interface;

class Interfaces : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)

public:
    enum Roles {
        RoleName,
        RoleDisplayName
    };
    explicit Interfaces(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE Interface* get(int index) const;
    Q_INVOKABLE Interface* findByName(const QString &name) const;

private:
    QList<Interface*> m_list;
};

#endif // INTERFACES_H
