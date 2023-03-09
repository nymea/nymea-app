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
    // Ignoring return codes:
    // 1638: A newer version of the redist is already installed. Given the other application may remove the redist package upon uninstall, let's not bother and still use our own.
    // 3010: The system requires a restart. May be triggered if the machine already had a reboot pending before starting us.
    component.addOperation("Execute", "{0,1638,3010}", "@TargetDir@/vc_redist.x64.exe", "/quiet", "/norestart");
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/nymea-app.exe", "@StartMenuDir@/nymea app.lnk",
            "workingDirectory=@TargetDir@", "iconPath=@TargetDir@/logo.ico",
            "description=nymea:app - The nymea frontend");
    }
}
