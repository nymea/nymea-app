#ifndef INTERFACES_H
#define INTERFACES_H

#include <QAbstractListModel>
#include <QVariant>
#include <QSortFilterProxyModel>

class Interface;
class ParamType;
class ParamTypes;
class Devices;

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

    // helpers to populate the model
    void addInterface(const QString &name, const QString &displayName);
    void addEventType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes);
    void addActionType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes);
    void addStateType(const QString &interfaceName, const QString &name, QVariant::Type type, bool writable, const QString &displayName, const QString &displayNameEvent, const QString &displayNameAction = QString());

    ParamTypes* createParamTypes(const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue = QVariant(), const QVariant &minValue = QVariant(), const QVariant &maxValue = QVariant());
    void addParamType(ParamTypes* paramTypes, const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue = QVariant(), const QVariant &minValue = QVariant(), const QVariant &maxValue = QVariant());
};


#endif // INTERFACES_H
