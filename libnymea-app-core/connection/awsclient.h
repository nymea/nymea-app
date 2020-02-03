/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef AWSCLIENT_H
#define AWSCLIENT_H

#include <QObject>
#include <QNetworkRequest>
#include <QDate>
#include <QAbstractListModel>
#include <QPointer>

class QNetworkAccessManager;

class AWSDevice: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)

public:
    AWSDevice(const QString &id, const QString &name, bool online = false, QObject *parent = nullptr);
    QString id() const;
    QString name() const;
    void setName(const QString &name);
    bool online() const;
    void setOnline(bool online);

signals:
    void onlineChanged();
    void nameChanged();

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
        LoginErrorUnknownError,
        LoginErrorNetworkError
    };
    Q_ENUM(LoginError)

    static AWSClient* instance();

    bool isLoggedIn() const;
    QString username() const;
    QString userId() const;
    AWSDevices* awsDevices() const;
    bool confirmationPending() const;

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void signup(const QString &username, const QString &password);
    Q_INVOKABLE void confirmRegistration(const QString &code);
    Q_INVOKABLE void forgotPassword(const QString &username);
    Q_INVOKABLE void confirmForgotPassword(const QString &username, const QString &code, const QString &newPassword);
    Q_INVOKABLE void deleteAccount();

    Q_INVOKABLE void unpairDevice(const QString &coreId);

    Q_INVOKABLE void fetchDevices();

    Q_INVOKABLE bool postToMQTT(const QString &coreId, const QString &nonce, QObject* sender, std::function<void(bool)> callback);
    Q_INVOKABLE void getId();

    Q_INVOKABLE void registerPushNotificationEndpoint(const QString &registrationId, const QString &deviceDisplayName, const QString mobileDeviceId, const QString &mobileDeviceManufacturer, const QString &mobileDeviceModel);


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
        QueuedCall(const QString &method, const QString &arg1, const QString &arg2, const QString &arg3, const QString &arg4, const QString &arg5): method(method), arg1(arg1), arg2(arg2), arg3(arg3), arg4(arg4), arg5(arg5) { }
        QueuedCall(const QString &method, const QString &arg1, const QString &arg2, QObject* sender, std::function<void(bool)> callback): method(method), arg1(arg1), arg2(arg2), sender(sender), callback(callback) {}
        QString method;
        QString arg1;
        QString arg2;
        QString arg3;
        QString arg4;
        QString arg5;
        QPointer<QObject> sender;
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
    QString m_usedConfig = "";
    AWSDevices *m_devices;
};

#endif // AWSCLIENT_H
