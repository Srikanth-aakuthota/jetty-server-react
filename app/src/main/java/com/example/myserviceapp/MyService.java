package com.example.myserviceapp;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

public class MyService extends Service {
    private boolean isRunning;
    private Thread backgroundThread;

    @Override
    public void onCreate() {
        super.onCreate();
        isRunning = true;
        backgroundThread = new Thread(() -> {
            while (isRunning) {
                Log.d("MyService", "Service is running...");
                try {
                    Thread.sleep(5000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        });
        backgroundThread.start();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Can return START_STICKY to restart service if it's killed
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        isRunning = false;
        backgroundThread.interrupt();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null; // Not a bound service
    }
}
