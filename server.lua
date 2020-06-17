local tGUI = {}

local db_connection = dbConnect( "sqlite", "file.db" )

addEventHandler( "onResourceStart", resourceRoot, function()

    db_connection:exec( "CREATE TABLE IF NOT EXISTS test_data( name char(40), level int(10) )" )

    if fileExists( "test_xml.xml" ) then return end

    local xml_node = xmlCreateFile( "test_xml.xml", "data_storage" )

    xml_node:saveFile()
    xml_node:unload()

end )

local function push_data_to_xml( player, table_data )

    local xml_main_node = xmlLoadFile( "test_xml.xml" )

    local table_children = xml_main_node:getChildren()

    table_data.is_xml = true

    for _, node in pairs( table_children ) do 

        if node.name == "user_info" then
            local table_node_info = node:getAttributes()

            if table_node_info.user_name == table_data.user_name then

                if table_node_info.user_level == table_data.user_level then

                    outputChatBox( "Такие данные уже есть", player )

                    xml_main_node:unload()

                    return

                end

                node:setAttribute( "user_level", table_data.user_level )

                xml_main_node:saveFile()

                xml_main_node:unload()

                outputChatBox( "Данные обновлены", player )

                triggerEvent( "on_modify_db_data", resourceRoot, table_data )

                return

            end
        end

    end



    local new_node = xml_main_node:createChild( "user_info" )

    new_node:setAttribute( "user_name", table_data.user_name )

    new_node:setAttribute( "user_level", table_data.user_level )

    xml_main_node:saveFile()

    xml_main_node:unload()

    triggerEvent( "on_push_data_to_db", resourceRoot, table_data )

    outputChatBox( "Данные добавлены", player )

end

-- local function destroy_all_xml()

--     fileDelete( "test_xml.xml" )

--     local xml_node = xmlCreateFile( "test_xml.xml", "data_storage" )

--     xml_node:saveFile()
--     xml_node:unload()
-- end

local function get_all_data_from_xml()

    local xml_main_node = xmlLoadFile( "test_xml.xml" )

    local table_children = xml_main_node:getChildren()

    local tRes = {}

    for _, node in pairs( table_children ) do 

        local node_info = node:getAttributes()

        tRes[node_info.user_name] = node_info.user_level

        --iprint( "Ник = " .. node_info.user_name .. ", уровень = " .. node_info.user_level )

    end

    xml_main_node:unload()

    return tRes
end

local function destroy_xml_node( player, table_data )

    local xml_main_node = xmlLoadFile( "test_xml.xml" )

    local table_children = xml_main_node:getChildren()


    for _, node in pairs( table_children ) do 

        if node.name == "user_info" then
            local table_node_info = node:getAttributes()

            if table_node_info.user_name == table_data.user_name and table_node_info.user_level == table_data.user_level then

                outputChatBox( "Удалено", player )

                node:destroy()

                xml_main_node:saveFile()
                xml_main_node:unload()

                table_data.is_xml = true

                triggerEvent( "on_modify_db_data", resourceRoot, table_data )

                return

            end

 
        end

        --iprint(node:getAttributes())

    end


    outputChatBox( "Такового узла нет", player )

    xml_main_node:unload()

end

local function get_data_from_sqlite( player, table_data )

    if table_data then
        local table_result = db_connection:query( "SELECT * FROM test_data WHERE name = ?", table_data.user_name ):poll( -1 )

        --iprint(#table_result)
        
        if #table_result == 0 then
            db_connection:exec( "INSERT INTO test_data VALUES ( ?, ? )", table_data.user_name, table_data.user_level )

            outputChatBox( "Информация добавлена", player )

            triggerEvent( "on_push_data_to_db", resourceRoot, table_data )

        elseif table_result[1].level ~= table_data.user_level then
            db_connection:exec( "UPDATE test_data SET level = ? WHERE name = ?", table_data.user_level, table_data.user_name )

            outputChatBox( "Информация обновлена", player )

            triggerEvent( "on_modify_db_data", resourceRoot, table_data )

        else
            outputChatBox( "Такие данные уже есть в БД", player )
        end

    else
        local table_tmp_result = db_connection:query( "SELECT * FROM test_data" ):poll( -1 )

        local table_result = {}

        for _, table_row_data in pairs( table_tmp_result ) do 

            table_result[ table_data.name ] = table_row_data.level

        end

        --iprint( table_result )
        return table_result
    end

end

local function del_data_from_sqlite( player, table_data )

    local data_from_sqlite = db_connection:query( "SELECT * FROM test_data WHERE name = ? and level = ?", table_data.user_name, table_data.user_level ):poll( -1 )
    
    if #data_from_sqlite == 0 then
        outputChatBox( "Таких данных нет", player )
        return
    end

    db_connection:exec( "DELETE FROM test_data WHERE name = ? and level = ?", table_data.user_name, table_data.user_level )
    outputChatBox( "Данные удалены", player )

    triggerEvent( "on_modify_db_data", resourceRoot, table_data )
end

addCommandHandler( "add_xml", function( thePlayer, _, nick, level )

    if not nick or not tonumber( level ) then return end

    push_data_to_xml( thePlayer, { user_name = nick, user_level = level } )

end )

addCommandHandler( "add_sqlite", function( thePlayer, _, nick, level )

    if not nick or not tonumber( level ) then return end

    get_data_from_sqlite( thePlayer, { user_name = nick, user_level = tonumber( level ) } )


end )

addCommandHandler( "del_sqlite", function( thePlayer, _, nick, level )

    if not nick or not tonumber( level ) then return end

    del_data_from_sqlite( thePlayer, { user_name = nick, user_level = tonumber( level ) } )

end )

addCommandHandler( "del_xml", function( thePlayer, _, nick, level )

    if not nick or not tonumber( level ) then return end

    destroy_xml_node( thePlayer, { user_name = nick, user_level = level } )

end )

addEvent( "on_modify_db_data", true )
addEventHandler( "on_modify_db_data", resourceRoot, function( table_data )

    for player, _ in pairs( tGUI ) do
        triggerClientEvent( player, "on_modify_gui_row", resourceRoot, table_data )
    end

end )

addEvent( "on_push_data_to_db", true )
addEventHandler( "on_push_data_to_db", resourceRoot, function( table_data )

    for player, _ in pairs( tGUI ) do
        triggerClientEvent( player, "on_adding_gui_row", resourceRoot, table_data )
    end

end )

addCommandHandler( "open_gui", function( thePlayer )

    if tGUI[thePlayer] then return end

    tGUI[thePlayer] = true

    local data_from_server = get_all_data_from_xml()

    --iprint(data_from_server)

    data_from_server.is_xml = true

    local data_from_sqlite = get_data_from_sqlite( thePlayer )

    triggerClientEvent( thePlayer, "on_opening_gui", resourceRoot, data_from_server )

    triggerClientEvent( thePlayer, "on_opening_gui", resourceRoot, data_from_sqlite )

end )

addEvent( "on_closing_gui", true )
addEventHandler( "on_closing_gui", resourceRoot, function()

    tGUI[client] = nil

end )

addEventHandler ( "onPlayerQuit", root, function()
    tGUI[source] = nil
end )