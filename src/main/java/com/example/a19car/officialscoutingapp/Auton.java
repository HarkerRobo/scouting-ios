package com.example.a19car.officialscoutingapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.ToggleButton;

public class Auton extends AppCompatActivity {

    Button teleop;
    ToggleButton baseline;
    Boolean baselineCrossed;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_auton);
        Teleop();
    }

    public void Teleop() {
        teleop = (Button) findViewById(R.id.AutonToTeleop);
        teleop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent toy = new Intent(Auton.this,Input.class);
                startActivity(toy);
            }
        });
    }

    public void baseline() {
        baseline = (ToggleButton) findViewById(R.id.baseline);
        baseline.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    baselineCrossed = true;
                } else {
                    baselineCrossed = false;
                }
            }
        });
    }

}
