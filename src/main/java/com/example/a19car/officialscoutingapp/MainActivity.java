package com.example.a19car.officialscoutingapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "ScoutingApp";
    public Button start;
    public Button text;
    JSONArray data;
    JSONArray results;
    int year;
    String name;
    String id;
    int round;
    int rank;
    Boolean blue;
    int team;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        startButton();
        textButton();
    }

    public void startButton() {
        start = (Button) findViewById(R.id.start);
        start.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent toy = new Intent(MainActivity.this,Auton.class);
                startActivity(toy);
            }
        });
    }

    public void textButton() {
        text = (Button) findViewById(R.id.text);
        text.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "This is the start button message");
                Toast.makeText(getApplicationContext(), "Loading...", Toast.LENGTH_SHORT)
                        .show();
            }
        });
    }

    protected void jsonParser () {
        try {
            JSONObject t = data.getJSONObject(0);
            JSONObject s = data.getJSONObject(1);
            year = t.getInt("year");
            name = t.getString("name");
            id = t.getString("id");
            round = s.getInt("round");
            rank = s.getInt("rank");
            blue = s.getBoolean("blue");
            team = s.getInt("team");
            results.put("headers");
            results.put("data");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
