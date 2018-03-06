package com.example.a19car.officialscoutingapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.ToggleButton;

public class Final extends AppCompatActivity {

    public Button done;
    public ToggleButton climb;
    public ToggleButton platform;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_final);
        done();
    }
    public void done() {
        done = (Button) findViewById(R.id.done);
        done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent results = new Intent(Final.this,MainActivity.class);
                startActivity(results);
            }
        });
    }
}
