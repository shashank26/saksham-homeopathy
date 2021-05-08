package com.sakshamglobalclinic.saksham_homeopathy
// package com.ibis.saksham_homeopathy
import android.app.NotificationManager;
import android.content.Context;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onResume() {
    super.onResume()
    cancelAllNotifications();
  }

  private fun cancelAllNotifications() {
       val notificationManager = ContextCompat.getSystemService(this,
            NotificationManager::class.java) as NotificationManager;
        notificationManager.cancelAll();
    }

}