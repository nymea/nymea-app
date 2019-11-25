#ifndef SCRIPTS_H
#define SCRIPTS_H

#include <QObject>
#include <QAbstractListModel>

class Script;

class Scripts : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId,
        RoleName
    };

    explicit Scripts(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void clear();
    void addScript(Script *script);
    void removeScript(const QUuid &id);

    Q_INVOKABLE Script *get(int index) const;
    Q_INVOKABLE Script *getScript(const QUuid &scriptId);

signals:
    void countChanged();

private:
    QList<Script*> m_list;

};

#endif // SCRIPTS_H
