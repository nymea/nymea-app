function Component()
{
    gui.pageWidgetByObjectName("LicenseAgreementPage").entered.connect(changeLicenseLabels);
}

changeLicenseLabels = function()
{
    page = gui.pageWidgetByObjectName("LicenseAgreementPage");
    page.AcceptLicenseLabel.setText("Yes, I agree");
    page.RejectLicenseLabel.setText("No, I disagree");
}

Component.prototype.createOperations = function()
{
    component.createOperations();
    // Ignoring return code 1638, which means a newer version of the redist is already installed
    component.addOperation("Execute", "{0,1638}", "@TargetDir@/vc_redist.x64.exe", "/quiet", "/norestart");
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/nymea-app.exe", "@StartMenuDir@/nymea app.lnk",
            "workingDirectory=@TargetDir@", "iconPath=@TargetDir@/logo.ico",
            "description=nymea:app - The nymea frontend");
    }
}
