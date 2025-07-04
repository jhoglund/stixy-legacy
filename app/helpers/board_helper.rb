module BoardHelper
	include CalendarHelper

  def show_promotion?
    (!current_user.authorized? and @board.id and not params[:action]=="sample") or params[:board_promo_test]
  end
  
  def body_classes
    return  "#{current_user.pref_ui_board_list==0 ? "board-list-closed" : "board-list-open"} " + 
            "#{current_user.pref_ui_widget_tray==0 ? "tray-closed" : "tray-open"} " +
            "#{current_user.pref_ui_board_options==0 ? "bopt-closed" : "bopt-open"} " +
            "wopt-closed saved widget-deactivated"
  end
end
