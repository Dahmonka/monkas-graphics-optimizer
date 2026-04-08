local ADDON_NAME = ...

local OPTIMIZED_CVARS = {
    { "graphicsShadowQuality", "1" },
    { "graphicsLiquidDetail", "0" },
    { "graphicsParticleDensity", "5" },
    { "graphicsSSAO", "0" },
    { "graphicsDepthEffects", "0" },
    { "graphicsComputeEffects", "0" },
    { "graphicsOutlineMode", "0" },
    { "graphicsTextureResolution", "2" },
    { "graphicsSpellDensity", "1" },
    { "graphicsProjectedTextures", "1" },
    { "graphicsViewDistance", "1" },
    { "graphicsEnvironmentDetail", "1" },
    { "graphicsGroundClutter", "1" },
    { "RAIDsettingsEnabled", "0" },
    { "ResampleAlwaysSharpen", "1" },
}

local DISPLAY_NAME = "Monka's Graphics Optimizer"
local BUTTON_LABEL = "Optimize Graphics"

local function PrintMessage(message)
    print(string.format("|cff33cc99[%s]|r %s", ADDON_NAME or DISPLAY_NAME, message))
end

local function ApplyOptimizedGraphics()
    if InCombatLockdown() then
        PrintMessage("Cannot apply graphics settings during combat.")
        return false
    end

    for _, entry in ipairs(OPTIMIZED_CVARS) do
        SetCVar(entry[1], entry[2])
    end

    local currentContrast = tonumber(GetCVar("Contrast")) or 50
    if currentContrast <= 55 then
        SetCVar("Contrast", tostring(currentContrast + 10))
    end

    PrintMessage("Applied FPS and graphics optimization settings.")
    return true
end

local function FindGameMenuButton(menuFrame, ...)
    if not menuFrame or not menuFrame.buttonPool then
        return
    end

    for menuButton in menuFrame.buttonPool:EnumerateActive() do
        local text = menuButton:GetText()
        for index = 1, select("#", ...) do
            if text == select(index, ...) then
                return menuButton
            end
        end
    end
end

local function InsertGameMenuButtonBefore(menuFrame, button, referenceButton)
    if not referenceButton or not referenceButton.layoutIndex then
        return
    end

    local referenceIndex = referenceButton.layoutIndex
    for menuButton in menuFrame.buttonPool:EnumerateActive() do
        if menuButton ~= button and menuButton.layoutIndex and menuButton.layoutIndex >= referenceIndex then
            menuButton.layoutIndex = menuButton.layoutIndex + 1
        end
    end

    button.layoutIndex = referenceIndex
    button.topPadding = referenceButton.topPadding
    referenceButton.topPadding = nil
end

local function AddGameMenuButton(menuFrame)
    if not menuFrame or type(menuFrame.AddButton) ~= "function" or not menuFrame.buttonPool then
        return
    end

    local button = menuFrame:AddButton(BUTTON_LABEL, function()
        if ApplyOptimizedGraphics() then
            HideUIPanel(menuFrame)
        end
    end)

    local referenceButton = FindGameMenuButton(
        menuFrame,
        ADDONS,
        GAMEMENU_NEW_BUTTON,
        HUD_EDIT_MODE_MENU,
        GAMEMENU_SUPPORT,
        MACROS,
        GameMenuFrameMixin and GameMenuFrameMixin.GetLogoutText and menuFrame:GetLogoutText() or LOG_OUT,
        EXIT_GAME,
        RETURN_TO_GAME
    )

    if referenceButton then
        InsertGameMenuButtonBefore(menuFrame, button, referenceButton)
    end

    if type(menuFrame.MarkDirty) == "function" then
        menuFrame:MarkDirty()
    elseif type(menuFrame.Layout) == "function" then
        menuFrame:Layout()
    end
end

local function InitializeGameMenuButton()
    if not GameMenuFrame or type(GameMenuFrame.AddButton) ~= "function" then
        return
    end

    hooksecurefunc(GameMenuFrame, "InitButtons", AddGameMenuButton)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent(event)
    InitializeGameMenuButton()
end)