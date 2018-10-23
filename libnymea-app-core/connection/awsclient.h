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
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
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
    bool busy() const;
    void setBusy(bool busy);
    Q_INVOKABLE AWSDevice* getDevice(const QString &uuid) const;
    Q_INVOKABLE AWSDevice* get(int index) const;
    void insert(AWSDevice *device);
    void remove(const QString &uuid);
    void clear();
signals:
    void countChanged();
    void busyChanged();
private:
    QList<AWSDevice*> m_list;
    bool m_busy = false;
};

class AWSConfiguration {
public:
    QByteArray clientId;
    QString poolId;
    QString identityPoolId;
    QString certificateEndpoint;
    QString certificateApiKey;
    QString certificateVendorId;
    QString mqttEndpoint;
    QString region;
    QString apiEndpoint;
    QString pushNotificationSystem;
};

class AWSClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY isLoggedInChanged)
    Q_PROPERTY(QString username READ username NOTIFY isLoggedInChanged)
    Q_PROPERTY(bool confirmationPending READ confirmationPending NOTIFY confirmationPendingChanged)
    Q_PROPERTY(QString userId READ userId NOTIFY isLoggedInChanged)
    Q_PROPERTY(QByteArray idToken READ idToken NOTIFY isLoggedInChanged)
    Q_PROPERTY(AWSDevices* awsDevices READ awsDevices CONSTANT)

    Q_PROPERTY(QStringList availableConfigs READ availableConfigs CONSTANT)
    Q_PROPERTY(QString config READ config WRITE setConfig NOTIFY configChanged)

public:
    enum LoginError {
        LoginErrorNoError,
        LoginErrorInvalidUserOrPass,
        LoginErrorInvalidCode,
        LoginErrorUserExists,
        LoginErrorLimitExceeded,
        LoginErrorUnknownError
    };
    Q_ENUM(LoginError)

    static AWSClient* instance();

    bool isLoggedIn() const;
    QString username() const;
    QString userId() const;
    AWSDevices* awsDevices() const;
    bool confirmationPending() const;

    Q_INVOKABLE void login(const QString &username, const QString &password, int attempt = -1);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void signup(const QString &username, const QString &password);
    Q_INVOKABLE void confirmRegistration(const QString &code);
    Q_INVOKABLE void forgotPassword(const QString &username);
    Q_INVOKABLE void confirmForgotPassword(const QString &username, const QString &code, const QString &newPassword);
    Q_INVOKABLE void deleteAccount();

    Q_INVOKABLE void unpairDevice(const QString &boxId);

    Q_INVOKABLE void fetchDevices();

    Q_INVOKABLE bool postToMQTT(const QString &boxId, const QString &timestamp, std::function<void(bool)> callback);
    Q_INVOKABLE void getId();

    Q_INVOKABLE void registerPushNotificationEndpoint(const QString &registrationId, const QString &deviceDisplayName, const QString mobileDeviceId);

    bool tokensExpired() const;
    QByteArray idToken() const;
    QString cognitoIdentityId() const;

    void fetchCertificate(const QString &uuid, std::function<void(const QByteArray &rootCA, const QByteArray &certificate, const QByteArray &publicKey, const QByteArray &privateKey, const QString &endpoint)> callback);

    QStringList availableConfigs() const;
    QString config() const;
    void setConfig(const QString &config);

signals:
    void loginResult(LoginError error);
    void signupResult(LoginError error);
    void confirmationResult(LoginError error);
    void forgotPasswordResult(LoginError error);
    void confirmForgotPasswordResult(LoginError error);
    void deleteAccountResult(LoginError error);

    void isLoggedInChanged();
    void confirmationPendingChanged();
    void devicesFetched();

    void configChanged();

private:
    explicit AWSClient(QObject *parent = nullptr);
    static AWSClient* s_instance;

    void refreshAccessToken();
    void getCredentialsForIdentity(const QString &identityId);
    void connectMQTT();


private:
    QNetworkAccessManager *m_nam = nullptr;

    QString m_userId;
    QString m_username;
    QString m_password;

    bool m_loginInProgress = false;

    bool m_confirmationPending = false;

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
        QueuedCall(const QString &method, const QString &arg1): method(method), arg1(arg1) { }
        QueuedCall(const QString &method, const QString &arg1, const QString &arg2, const QString &arg3): method(method), arg1(arg1), arg2(arg2), arg3(arg3) { }
        QueuedCall(const QString &method, const QString &arg1, const QString &arg2, std::function<void(bool)> callback): method(method), arg1(arg1), arg2(arg2), callback(callback) {}
        QString method;
        QString arg1;
        QString arg2;
        QString arg3;
        std::function<void(bool)> callback;

        static void enqueue(QList<QueuedCall> &queue, const QueuedCall &call) {
            foreach (const QueuedCall &existingCall, queue) {
                if (existingCall.method == call.method &&
                        existingCall.arg1 == call.arg1 &&
                        existingCall.arg2 == call.arg2 &&
                        existingCall.arg3 == call.arg3 &&
                        &existingCall.callback == &call.callback) {
                    return; // Already in queue
                }
            }
            queue.append(call);
        }
    };

    QList<QueuedCall> m_callQueue;

    QHash<QString, AWSConfiguration> m_configs;
    QString m_usedConfig = "community";
    AWSDevices *m_devices;
};

#endif // AWSCLIENT_H
