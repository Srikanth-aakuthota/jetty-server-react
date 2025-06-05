package com.example.myserviceapp;

import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Show the layout with Hello World
        setContentView(R.layout.activity_main);
        startService(new Intent(this, MyService.class));
    }
}
