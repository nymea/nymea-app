#include <QtTest/QTest>

#include "connection/sigv4utils.h"

class TestSigV4: public QObject
{
    Q_OBJECT
public:
    TestSigV4(QObject* parent = nullptr);

private slots:
    void canonicalRequest_data();
    void canonicalRequest();

private:
    QString m_region = "us-east-1";
    QString m_service = "service";
    QByteArray m_accessKeyId = "AKIDEXAMPLE";
    QByteArray m_secretAccessKey = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY";
};

Q_DECLARE_METATYPE(QNetworkAccessManager::Operation)

TestSigV4::TestSigV4(QObject *parent): QObject(parent)
{
}

void TestSigV4::canonicalRequest_data() {
    QTest::addColumn<QNetworkAccessManager::Operation>("method");
    QTest::addColumn<QByteArray>("dateTime");
    QTest::addColumn<QNetworkRequest>("request");
    QTest::addColumn<QByteArray>("payload");
    QTest::addColumn<QByteArray>("expectedCanonicalRequest");
    QTest::addColumn<QByteArray>("expectedStringToSign");
    QTest::addColumn<QByteArray>("expectedSignature");


    QDir dir(TESTDATADIR);
    foreach (const QString &subDirName, dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QDir subDir(QString(TESTDATADIR) + '/' + subDirName);
        if(subDir.entryList({"*.req"}).count() != 1) {
            qWarning() << "Skipping folder:" << subDir.absolutePath();
            continue;
        }
        QFile f(subDir.entryInfoList({"*.req"}).first().absoluteFilePath());
        f.open(QFile::ReadOnly);

        // line 1, read operation and path
        QByteArray line = f.readLine();
        QByteArray methodString = line.split(' ').first();
        QNetworkAccessManager::Operation operation;
        if (methodString == "GET") {
            operation = QNetworkAccessManager::GetOperation;
        } else if (methodString == "POST") {
            operation = QNetworkAccessManager::PostOperation;
        }
        QByteArray path = line.split(' ').at(1);



        QNetworkRequest request;
        QByteArray host;
        QByteArray dateTime;

        // read headers
        QByteArray lastHeaderName;
        while (!f.atEnd()) {
            QByteArray line = f.readLine().trimmed();
            if (line.isEmpty()) {
                break;
            }
            QByteArray header = QString(line).replace(QRegExp("[\\ ]{1,}"), " ").toUtf8();
            if (!header.contains(':')) {
                request.setRawHeader(lastHeaderName, request.rawHeader(lastHeaderName) + ',' + header);
                continue;
            }
            QByteArray headerName = header.split(':').first().trimmed();
            QByteArray headerValue = header.split(':').last().trimmed();
            qDebug() << "working on header:" << headerName << headerValue;
            if (headerName == "Host") {
                 host = headerValue;
            }
            if (headerName == "X-Amz-Date") {
                dateTime = headerValue;
            }
            if (!request.hasRawHeader(headerName)) {
                request.setRawHeader(headerName, headerValue);
            } else {
                request.setRawHeader(headerName, request.rawHeader(headerName) + ',' + headerValue);
            }
            lastHeaderName = headerName;
        }

        QByteArray payload;
        if (!f.atEnd()) {
            payload = f.readAll();
        }

        QUrl url = QUrl(QString("https://" + host + path));
        request.setUrl(url);

        // read creq file
        QFile creq(subDir.entryInfoList({"*.creq"}).first().absoluteFilePath());
        creq.open(QFile::ReadOnly);

        // read sts file
        QFile sts(subDir.entryInfoList({"*.sts"}).first().absoluteFilePath());
        sts.open(QFile::ReadOnly);

        // read authz file
        QFile authz(subDir.entryInfoList({"*.authz"}).first().absoluteFilePath());
        authz.open(QFile::ReadOnly);

        QTest::newRow(f.fileName().split('/').last().toUtf8()) << operation << dateTime << request << payload << creq.readAll() << sts.readAll() << authz.readAll();
    }


}

void TestSigV4::canonicalRequest()
{
    QFETCH(QNetworkAccessManager::Operation, method);
    QFETCH(QByteArray, dateTime);
    QFETCH(QNetworkRequest, request);
    QFETCH(QByteArray, payload);
    QFETCH(QByteArray, expectedCanonicalRequest);
    QFETCH(QByteArray, expectedStringToSign);
    QFETCH(QByteArray, expectedSignature);

    qDebug() << "Request:" << request.url() << "Host:" << request.url().host() << "Path:" << request.url().path() << "Query:" << request.url().query();
    QByteArray canonicalRequest = SigV4Utils::getCanonicalRequest(method, request, payload);

    QCOMPARE(canonicalRequest, expectedCanonicalRequest);

    QByteArray stringTosign = SigV4Utils::getStringToSign(canonicalRequest, dateTime, m_region.toUtf8(), m_service.toUtf8());

    QCOMPARE(stringTosign, expectedStringToSign);

    QByteArray signature = SigV4Utils::getSignature(stringTosign, m_secretAccessKey, dateTime, m_region, m_service);

    QByteArray signHeader = SigV4Utils::getAuthorizationHeader(m_accessKeyId, dateTime, m_region, m_service, request, signature);

    QCOMPARE(signHeader, expectedSignature);
//    qDebug() << "CanonicalRequest" << canonicalRequest;

}

#include "testsigv4.moc"
QTEST_MAIN(TestSigV4)

