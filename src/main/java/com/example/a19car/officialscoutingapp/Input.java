package com.example.a19car.officialscoutingapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.Toast;

import org.json.JSONArray;

public class Input extends AppCompatActivity {
    public Button rSwitch;
    public Button bSwitch;
    public Button rVault;
    public Button bVault;
    public Button scale;
    public Button done;

    public int rSwitchCount = 0;
    public int bSwitchCount = 0;
    public int rVaultCount = 0;
    public int bVaultCount = 0;
    public int scaleCount = 0;

    JSONArray data = new JSONArray();


    private static final String TAG = "ScoutingApp";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_input);
        rSwitch();
        bSwitch();
        rVault();
        bVault();
        scale();
        done();
    }

    public void rSwitch() {
        rSwitch = (Button) findViewById(R.id.rswitch);
        rSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                rSwitchCount++;
            }
        });
    }

    public void bSwitch() {
        bSwitch = (Button) findViewById(R.id.bswitch);
        bSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                bSwitchCount++;
            }
        });
    }

    public void rVault() {
        rVault = (Button) findViewById(R.id.rvault);
        rVault.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                rVaultCount++;
            }
        });
    }

    public void bVault() {
        bVault = (Button) findViewById(R.id.bvault);
        bVault.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                bVaultCount++;
            }
        });
    }

    public void scale() {
        scale = (Button) findViewById(R.id.scale);
        scale.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                scaleCount++;
            }
        });
    }

    public void done() {
        done = (Button) findViewById(R.id.done);
        done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent results = new Intent(Input.this,Final.class);
                startActivity(results);
            }
        });
    }
}
