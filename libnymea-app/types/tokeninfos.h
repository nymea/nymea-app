#ifndef TOKENINFOS_H
#define TOKENINFOS_H

#include <QAbstractListModel>

class TokenInfo;

class TokenInfos : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId,
        RoleUsername,
        RoleDeviceName,
        RoleCreationTime
    };

    explicit TokenInfos(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addToken(TokenInfo *tokenInfo);
    void removeToken(const QUuid &tokenId);

    Q_INVOKABLE TokenInfo* get(int index) const;

signals:
    void countChanged();

private:
    QList<TokenInfo*> m_list;
};

#endif // TOKENINFOS_H
