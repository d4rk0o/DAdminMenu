function RageUI.Info(Title, RightText, LeftText)
    local LineCount = 0
    local MaxTextWidth = 0

    if RightText then
        LineCount = math.max(LineCount, #RightText)
        for _, text in ipairs(RightText) do
            MaxTextWidth = math.max(MaxTextWidth, string.len(text))
        end
    end

    if LeftText then
        LineCount = math.max(LineCount, #LeftText)
        for _, text in ipairs(LeftText) do
            MaxTextWidth = math.max(MaxTextWidth, string.len(text))
        end
    end

    local TitleWidth = Title and string.len(Title) * 10 or 0  -- Estimation de la largeur du titre
    MaxTextWidth = math.max(MaxTextWidth * 7, TitleWidth)  -- Estimation de la largeur du texte le plus long

    local width = math.max(220, MaxTextWidth + 65)  -- Largeur minimale de 216, ajustée si nécessaire
    local height = (Title and 50 or 30) + (LineCount * 20)

    if Title then
        RenderText("~h~" .. Title .. "~h~", 330 + 20 + 100, 7, 0, 0.34, 255, 255, 255, 255, 0)
    end

    if RightText then
        RenderText(table.concat(RightText, "\n"), 330 + 20 + 100, Title and 37 or 7, 0, 0.28, 255, 255, 255, 255, 0)
    end

    if LeftText then
        RenderText(table.concat(LeftText, "\n"), 330 + width - 20 + 100, Title and 37 or 7, 0, 0.28, 255, 255, 255, 255, 2)
    end

    RenderRectangle(330 + 10 + 100, 0, width, height, 0, 0, 0, 160)
end

--RageUI.Info("Titre", {"Sous titre 1", "Sous titre 2", "Sous titre 3","Sous titre 4"}, {"Sous titre droite 1", "Sous titre droite 2", "Sous titre droite 3","Sous titre droite 4" })