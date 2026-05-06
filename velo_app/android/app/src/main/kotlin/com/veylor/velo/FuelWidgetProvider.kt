package com.veylor.velo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class FuelWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.fuel_widget).apply {
                val carName = widgetData.getString("widget_car_name", "ADD FUEL")
                setTextViewText(R.id.widget_title, carName?.uppercase() ?: "ADD FUEL")

                val carId = widgetData.getString("widget_car_id", "")
                
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context,
                    MainActivity::class.java,
                    Uri.parse("velo://add_fuel?carId=$carId"))
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
