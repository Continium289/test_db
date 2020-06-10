
addEventHandler( "onResourceStart", resourceRoot, function()

    if fileExists( "test_xml.xml" ) then return end

    local xml_node = xmlCreateFile( "test_xml.xml", "data_storage" )

    xml_node:saveFile()
    xml_node:unload()

end )

local function push_data_to_xml( data )

    local xml_main_node = xmlLoadFile( "test_xml.xml" )

    local table_children = xml_main_node:getChildren()


    for _, node in pairs( table_children ) do 

        if node.name == "user_info" then
            local table_node_info = node:getAttributes()

            if table_node_info.user_name == data.user_name then

                if table_node_info.user_level == data.user_level then

                    iprint( "Такие данные уже есть!" )

                    xml_main_node:unload()

                    return

                end

                node:setAttribute( "user_level", data.user_level )

                xml_main_node:saveFile()

                xml_main_node:unload()

                iprint( "Данные обновлены!" )

                return

            end
        end

        --iprint(node:getAttributes())

    end



    local new_node = xml_main_node:createChild( "user_info" )

    new_node:setAttribute( "user_name", data.user_name )

    new_node:setAttribute( "user_level", data.user_level )

    xml_main_node:saveFile()

    xml_main_node:unload()

    iprint( "Данные добавлены!" )

end

local function destroy_all_xml()

    fileDelete( "test_xml.xml" )

    local xml_node = xmlCreateFile( "test_xml.xml", "data_storage" )

    xml_node:saveFile()
    xml_node:unload()
end

local function print_all_data()

    local xml_main_node = xmlLoadFile( "test_xml.xml" )

    local table_children = xml_main_node:getChildren()

    for _, node in pairs( table_children ) do 

        local node_info = node:getAttributes()

        iprint( "Ник = " .. node_info.user_name .. ", уровень = " .. node_info.user_level )

    end

    xml_main_node:unload()
end

local function destroy_xml_node( data )

    local xml_main_node = xmlLoadFile( "test_xml.xml" )

    local table_children = xml_main_node:getChildren()


    for _, node in pairs( table_children ) do 

        if node.name == "user_info" then
            local table_node_info = node:getAttributes()

            if table_node_info.user_name == data.user_name and table_node_info.user_level == data.user_level then

                iprint( "Удалено!" )

                node:destroy()

                xml_main_node:saveFile()
                xml_main_node:unload()

                return

            end

 
        end

        --iprint(node:getAttributes())

    end


    iprint("Такового узла нет!")

    xml_node:unload()

end

addCommandHandler( "testing", function( _, _, nick )

    --push_data_to_xml( { user_name = nick, user_level = tostring( math.random( 0, 255 ) ) } )

    --destroy_xml_node( { user_name = "tmp_name", user_level = "30" } )

    --print_all_data()

    --destroy_all_xml()
end )