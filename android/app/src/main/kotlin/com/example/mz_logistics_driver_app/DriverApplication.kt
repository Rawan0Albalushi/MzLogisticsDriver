package com.example.mz_logistics_driver_app

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

/**
 * Creates the tracking foreground-service channel before any component can
 * start. [flutter_background_service] does not create a channel when a custom
 * id is configured, and Android kills the process with
 * "Bad notification for startForeground" if that channel is missing.
 *
 * The id must stay in sync with `AppConfig.trackingChannelId`.
 */
class DriverApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            TRACKING_CHANNEL_ID,
            getString(R.string.tracking_channel_name),
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = getString(R.string.tracking_channel_description)
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    companion object {
        const val TRACKING_CHANNEL_ID = "mz_driver_tracking"
    }
}
