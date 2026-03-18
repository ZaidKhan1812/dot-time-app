package com.example.dot_time

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
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

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.dot_time_widget)
            
            val cal = Calendar.getInstance()
            val progress = getDayProgress(cal)
            val percent = (progress * 100).toInt()
            
            views.setTextViewText(R.id.widget_mode, "Day")
            views.setTextViewText(R.id.widget_progress, "$percent% of day gone")
            
            val bitmap = createDotBitmap(progress, 300, 250)
            views.setImageViewBitmap(R.id.widget_dots, bitmap)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun getDayProgress(cal: Calendar): Float {
            val minutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
            return minutes / 1440f
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