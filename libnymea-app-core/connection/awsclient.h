#ifndef AWSCLIENT_H
#define AWSCLIENT_H

#include <QObject>
#include <QNetworkRequest>
#include <QDate>
#include <QAbstractListModel>

class QNetworkAccessManager;

class AWSDevice: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)

public:
    AWSDevice(const QString &id, const QString &name, bool online = false, QObject *parent = nullptr);
    QString id() const;
    QString name() const;
    bool online() const;
    void setOnline(bool online);

signals:
    void onlineChanged();

private:
    QString m_id;
    QString m_name;
    bool m_online;
};

class AWSDevices: public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleName,
        RoleId,
        RoleOnline
    };
    AWSDevices(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE AWSDevice* getDevice(const QString &uuid) const;
    Q_INVOKABLE AWSDevice* get(int index) const;
    void insert(AWSDevice *device);
signals:
    void countChanged();
private:
    QList<AWSDevice*> m_list;
};

class AWSClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
    Q_PROPERTY(QString username READ username NOTIFY isLoggedInChanged)
    Q_PROPERTY(QByteArray userId READ userId NOTIFY isLoggedInChanged)
    Q_PROPERTY(QByteArray idToken READ idToken NOTIFY isLoggedInChanged)
    Q_PROPERTY(AWSDevices* awsDevices READ awsDevices CONSTANT)

public:
    explicit AWSClient(QObject *parent = nullptr);

    bool isLoggedIn() const;
    QString username() const;
    QByteArray userId() const;
    AWSDevices* awsDevices() const;

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();

    Q_INVOKABLE void fetchDevices();

    Q_INVOKABLE bool postToMQTT(const QString &boxId, std::function<void(bool)> callback);
    Q_INVOKABLE void getId();

    bool tokensExpired() const;
    QByteArray idToken() const;
    QString cognitoIdentityId() const;

    void fetchCertificate(const QString &uuid, std::function<void(const QByteArray &rootCA, const QByteArray &certificate, const QByteArray &publicKey, const QByteArray &privateKey, const QString &endpoint)> callback);

signals:
    void isLoggedInChanged();
    void devicesFetched();

private:
    void refreshAccessToken();
    void getCredentialsForIdentity(const QString &identityId);
    void connectMQTT();


private:
    QNetworkAccessManager *m_nam = nullptr;

    QString m_username;
    QString m_password;

    QByteArray m_accessToken;
    QDateTime m_accessTokenExpiry;
    QByteArray m_idToken;
    QByteArray m_refreshToken;

    QByteArray m_identityId;

    QByteArray m_accessKeyId;
    QByteArray m_secretKey;
    QByteArray m_sessionToken;
    QDateTime m_sessionTokenExpiry;

    class QueuedCall {
    public:
        QueuedCall(const QString &method): method(method) { }
        QueuedCall(const QString &method, const QString &boxId, std::function<void(bool)> callback): method(method), boxId(boxId), callback(callback) {}
        QString method;
        QString boxId;
        std::function<void(bool)> callback;
    };

    QList<QueuedCall> m_callQueue;

    AWSDevices *m_devices;
};

#endif // AWSCLIENT_H
