
local UI_elements = {}

local sx, sy = guiGetScreenSize()


local function init_ui()

      showCursor( true )

      UI_elements.window = guiCreateWindow( sx / 4, sy / 4, sx / 2, sy / 2, "", false )

      UI_elements.tab_panel = guiCreateTabPanel( 0.01, 0.05, 0.8, 0.8, true, UI_elements.window )


      local function creation_new_tab( name )
            tab = guiCreateTab( name, UI_elements.tab_panel )

            grid = guiCreateGridList( 0, 0, 0.9, 0.9, true, tab )
            guiGridListAddColumn( grid, "Nick", 0.5 )
            guiGridListAddColumn( grid, "level", 0.5 )

            return tab, grid
      end

      UI_elements.tab_xml, UI_elements.grid_xml = creation_new_tab( "xml" )

      UI_elements.tab_mysql, UI_elements.grid_mysql = creation_new_tab( "SQLite" )

      UI_elements.close_button = guiCreateButton( 0, 0.9, 0.3, 0.3, "Закрыть", true, UI_elements.window)

      --iprint(UI_elements.close_button)

      addEventHandler ( "onClientGUIClick", UI_elements.close_button, function()
            
            UI_elements.window:destroy()

            UI_elements = {}

            triggerServerEvent( "on_closing_gui", resourceRoot )


            showCursor( false )
      end, false )

end

local function get_grid_element_by_name( is_xml )
      if not UI_elements.window then return end

      if is_xml then
            return UI_elements.grid_xml
      end

      return UI_elements.grid_mysql
end

local function filling_grid( tData )

      local grid_element = get_grid_element_by_name( tData.is_xml )

      tData.is_xml = nil

      for name, level in pairs( tData ) do
            grid_element:addRow( name, level )
      end

end

addEvent( "on_opening_gui", true )
addEventHandler( "on_opening_gui", resourceRoot, function( data_from_server )

      if not UI_elements.window then
            init_ui()
      end

      filling_grid( data_from_server )
end )

addEvent( "on_modify_gui_row", true )
addEventHandler( "on_modify_gui_row", resourceRoot, function( deleted_data )

      local grid_element = get_grid_element_by_name( deleted_data.is_xml )

      local row_count = guiGridListGetRowCount( grid_element )

      for i = 0, row_count - 1 do 

            if grid_element:getItemText( i, 1 ) == deleted_data.user_name then
                  if grid_element:getItemText( i, 2 ) == tostring( deleted_data.user_level ) then
                        grid_element:removeRow( i )
                        return
                  end
                  
                  grid_element:setItemText( i, 2, deleted_data.user_level, false, false )
            end

      end

end )

addEvent( "on_adding_gui_row", true )
addEventHandler( "on_adding_gui_row", resourceRoot, function( added_data )

      local grid_element = get_grid_element_by_name( added_data.is_xml )

      grid_element:addRow( added_data.user_name, added_data.user_level )

end )
  