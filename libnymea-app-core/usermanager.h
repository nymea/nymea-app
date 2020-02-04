#ifndef USERMANAGER_H
#define USERMANAGER_H

#include <QObject>

#include "jsonrpc/jsonrpcclient.h"
#include "engine.h"

#include "types/tokeninfos.h"

class UserManager: public JsonHandler
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

    Q_PROPERTY(TokenInfos* tokenInfos READ tokenInfos CONSTANT)

public:
    explicit UserManager(QObject *parent = nullptr);

    Engine* engine() const;
    void setEngine(Engine* engine);

    bool loading() const;

    TokenInfos* tokenInfos() const;

    QString nameSpace() const override;

signals:
    void engineChanged();
    void loadingChanged();

private slots:
    void notificationReceived(const QVariantMap &data);

    void getTokensReply(const QVariantMap &params);

private:
    Engine *m_engine = nullptr;
    bool m_loading = false;

    TokenInfos *m_tokenInfos = nullptr;
};

#endif // USERMANAGER_H
