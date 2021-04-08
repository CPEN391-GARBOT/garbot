package com.example.garbotapp;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import android.content.BroadcastReceiver;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.data.PieEntry;
import com.github.mikephil.charting.formatter.DefaultValueFormatter;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Objects;

public class MainActivity extends AppCompatActivity {
    private RequestQueue queue;
    private static String STATS_URL = "http://e348951796ba.ngrok.io/garbage/";
    private static String username;

    private Button day, week, month, year;
    private Button manualOverride;
    private PieChart pieChart;

    private TimeFrameSetter timeFrameSetter = new TimeFrameSetter();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        queue = Volley.newRequestQueue(getApplicationContext());
        username = Objects.requireNonNull(getIntent().getExtras()).getString("USERNAME");
        pieChart = findViewById(R.id.garbage_pie_chart);
        pieChart.setRotationEnabled(true);
        pieChart.setTransparentCircleAlpha(0);
        pieChart.setHoleRadius(10f);

        // Start by setting up a title for the page
        ActionBar actionBar = getSupportActionBar();
        if(actionBar != null) {
            String title = "Garbot";
            actionBar.setTitle(title);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        // Set up button functionality
        day = findViewById(R.id.day);
        day.setOnClickListener(view -> {
            resetButtons();
            day.setBackgroundColor(getResources().getColor(R.color.green_dark));
            populatePieChart(timeFrameSetter.getGarbage("Day"), timeFrameSetter.getPaper("Day"), timeFrameSetter.getCompost("Day"), timeFrameSetter.getRecycling("Day"));
        });
        week = findViewById(R.id.week);
        week.setOnClickListener(view -> {
            resetButtons();
            week.setBackgroundColor(getResources().getColor(R.color.green_dark));
            populatePieChart(timeFrameSetter.getGarbage("Week"), timeFrameSetter.getPaper("Week"), timeFrameSetter.getCompost("Week"), timeFrameSetter.getRecycling("Week"));
        });
        month = findViewById(R.id.month);
        month.setOnClickListener(view -> {
            resetButtons();
            month.setBackgroundColor(getResources().getColor(R.color.green_dark));
            populatePieChart(timeFrameSetter.getGarbage("Month"), timeFrameSetter.getPaper("Month"), timeFrameSetter.getCompost("Month"), timeFrameSetter.getRecycling("Month"));
        });
        year = findViewById(R.id.year);
        year.setOnClickListener(view -> {
            resetButtons();
            year.setBackgroundColor(getResources().getColor(R.color.green_dark));
            populatePieChart(timeFrameSetter.getGarbage("Year"), timeFrameSetter.getPaper("Year"), timeFrameSetter.getCompost("Year"), timeFrameSetter.getRecycling("Year"));
        });

        manualOverride = findViewById(R.id.manual_btn);
        manualOverride.setOnClickListener(view -> {
            Intent manualCIntent = new Intent(MainActivity.this, ManualControl.class);
            manualCIntent.putExtra("USERNAME", username);
            startActivity(manualCIntent);
        });

        retrieveStats();

        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter("newStats"));
    }

    // Retrieves stats from database
    private void retrieveStats() {
        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET, STATS_URL+username, null, response -> {
            if (response != null) {
                try {
                    JSONArray statsJson = response.getJSONArray("stats");

                    ArrayList<Integer> stats = new ArrayList<>();
                    ArrayList<Long> timestamps = new ArrayList<>();
                    for (int x = 0; x < statsJson.length(); x ++) {
                        JSONObject trash = statsJson.getJSONObject(x);
                        stats.add(trash.getInt("can"));
                        timestamps.add(trash.getLong("timestamp"));
                    }
                    timeFrameSetter.setTimeFrames(stats, timestamps);

                    resetButtons();
                    day.setBackgroundColor(getResources().getColor(R.color.green_dark));

                    populatePieChart(timeFrameSetter.getGarbage("Day"), timeFrameSetter.getPaper("Day"), timeFrameSetter.getCompost("Day"), timeFrameSetter.getRecycling("Day"));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                Toast.makeText(getApplicationContext(), "An error occurred when retrieving stats.", Toast.LENGTH_SHORT).show();
            }
        }, error -> {
            Toast.makeText(getApplicationContext(), "A network error occurred.", Toast.LENGTH_SHORT).show();
        });
        queue.add(jsonObjectRequest);
    }

    // Adds data onto the pie chart
    private void populatePieChart(int g, int p, int c, int r) {
        ArrayList<PieEntry> trashTypes = new ArrayList<>();
        trashTypes.add(new PieEntry(g, "Garbage"));
        trashTypes.add(new PieEntry(p, "Paper"));
        trashTypes.add(new PieEntry(c, "Compost"));
        trashTypes.add(new PieEntry(r, "Plastic"));

        ArrayList<Integer> colours = new ArrayList<>();
        colours.add(Color.BLACK);
        colours.add(Color.YELLOW);
        colours.add(Color.GREEN);
        colours.add(Color.BLUE);

        ArrayList<Integer> textColours = new ArrayList<>();
        textColours.add(Color.WHITE);
        textColours.add(Color.BLACK);
        textColours.add(Color.WHITE);
        textColours.add(Color.WHITE);


        PieDataSet pieDataSet = new PieDataSet(trashTypes, "");
        pieDataSet.setSliceSpace(2);
        pieDataSet.setValueTextSize(14);
        pieDataSet.setValueTextColors(textColours);
        pieDataSet.setColors(colours);
        pieDataSet.setValueFormatter(new DefaultValueFormatter(0));

        Legend legend = pieChart.getLegend();
        legend.setForm(Legend.LegendForm.CIRCLE);
        legend.setTextColor(Color.WHITE);

        PieData pieData = new PieData(pieDataSet);
        pieChart.setData(pieData);
        pieChart.getDescription().setEnabled(false);
        pieChart.invalidate();
    }

    // Resets all buttons to light green colour
    private void resetButtons() {
        day.setBackgroundColor(getResources().getColor(R.color.green_light));
        week.setBackgroundColor(getResources().getColor(R.color.green_light));
        month.setBackgroundColor(getResources().getColor(R.color.green_light));
        year.setBackgroundColor(getResources().getColor(R.color.green_light));
    }

    // Handler for broadcasts
    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d("receiver", "Got broadcast ");
            retrieveStats();
        }
    };

    @Override
    protected void onDestroy() {
        // Unregister since the activity is about to be closed.
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mMessageReceiver);
        super.onDestroy();
    }

    // Code to return to last page when the return button on the title bar is hit
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
    public boolean onCreateOptionsMenu(Menu menu) {
        return true;
    }
}
