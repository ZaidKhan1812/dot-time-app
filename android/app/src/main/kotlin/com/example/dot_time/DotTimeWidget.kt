package com.example.dot_time

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.widget.RemoteViews
import java.util.Calendar

class DotTimeWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val mode = intent.getStringExtra("MODE") ?: return
        val appWidgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        )
        val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
        prefs.edit().putString("mode_$appWidgetId", mode).apply()
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
            val mode = prefs.getString("mode_$appWidgetId", "Day") ?: "Day"
            val views = RemoteViews(context.packageName, R.layout.dot_time_widget)
            val cal = Calendar.getInstance()
            val progress = getProgress(cal, mode)
            val percent = (progress * 100).toInt()

            views.setTextViewText(R.id.widget_progress, "$percent% of $mode gone")

            // Update button styles
            views.setInt(R.id.btn_day, "setBackgroundResource",
                if (mode == "Day") R.drawable.widget_btn_selected else R.drawable.widget_btn_unselected)
            views.setInt(R.id.btn_month, "setBackgroundResource",
                if (mode == "Month") R.drawable.widget_btn_selected else R.drawable.widget_btn_unselected)
            views.setInt(R.id.btn_year, "setBackgroundResource",
                if (mode == "Year") R.drawable.widget_btn_selected else R.drawable.widget_btn_unselected)

            views.setTextColor(R.id.btn_day,
                if (mode == "Day") Color.BLACK else Color.WHITE)
            views.setTextColor(R.id.btn_month,
                if (mode == "Month") Color.BLACK else Color.WHITE)
            views.setTextColor(R.id.btn_year,
                if (mode == "Year") Color.BLACK else Color.WHITE)

            // Set click listeners
            for (btn in listOf("Day", "Month", "Year")) {
                val intent = Intent(context, DotTimeWidget::class.java).apply {
                    action = "android.appwidget.action.APPWIDGET_UPDATE"
                    putExtra("MODE", btn)
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                }
                val pi = PendingIntent.getBroadcast(
                    context,
                    appWidgetId * 10 + btn.hashCode(),
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val viewId = when (btn) {
                    "Day" -> R.id.btn_day
                    "Month" -> R.id.btn_month
                    else -> R.id.btn_year
                }
                views.setOnClickPendingIntent(viewId, pi)
            }

            // Draw dots
            val bitmap = createDotBitmap(progress, 300, 220)
            views.setImageViewBitmap(R.id.widget_dots, bitmap)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getProgress(cal: Calendar, mode: String): Float {
            return when (mode) {
                "Day" -> {
                    val minutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
                    minutes / 1440f
                }
                "Month" -> {
                    val day = cal.get(Calendar.DAY_OF_MONTH).toFloat()
                    val max = cal.getActualMaximum(Calendar.DAY_OF_MONTH).toFloat()
                    day / max
                }
                else -> {
                    val day = cal.get(Calendar.DAY_OF_YEAR).toFloat()
                    val max = cal.getActualMaximum(Calendar.DAY_OF_YEAR).toFloat()
                    day / max
                }
            }
        }

        private fun createDotBitmap(progress: Float, width: Int, height: Int): Bitmap {
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.BLACK)
            val cols = 15
            val rows = 12
            val totalDots = cols * rows
            val filledDots = (progress * totalDots).toInt()
            val dotRadius = 8f
            val spacingX = width.toFloat() / cols
            val spacingY = height.toFloat() / rows
            val paintFilled = Paint().apply {
                color = Color.parseColor("#FF6600")
                isAntiAlias = true
            }
            val paintEmpty = Paint().apply {
                color = Color.parseColor("#333333")
                isAntiAlias = true
            }
            var dotIndex = 0
            for (row in 0 until rows) {
                for (col in 0 until cols) {
                    val x = spacingX * col + spacingX / 2
                    val y = spacingY * row + spacingY / 2
                    val paint = if (dotIndex < filledDots) paintFilled else paintEmpty
                    canvas.drawCircle(x, y, dotRadius, paint)
                    dotIndex++
                }
            }
            return bitmap
        }
    }
}