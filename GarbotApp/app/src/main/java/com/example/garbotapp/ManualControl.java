package com.example.garbotapp;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;
import java.util.Objects;

public class ManualControl extends AppCompatActivity {
    private RequestQueue queue;
    private static String TRASH_URL = "http://e348951796ba.ngrok.io/garbage/";
    private static String username;
    private static int quantity;

    private TextView currentQ;
    private Button garbageBtn, compostBtn, paperBtn, recyclingBtn;
    private Button minusBtn, plusBtn;
    private Date date;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_manual_control);
        queue = Volley.newRequestQueue(getApplicationContext());
        username = Objects.requireNonNull(getIntent().getExtras()).getString("USERNAME");
        currentQ = (TextView) findViewById(R.id.quantityTextView);
        quantity = 1;
        date = new Date();

        // Start by setting up a title for the page
        ActionBar actionBar = getSupportActionBar();
        if(actionBar != null) {
            String title = "Manual Control";
            actionBar.setTitle(title);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        garbageBtn = findViewById(R.id.garbage_btn);
        garbageBtn.setOnClickListener(view -> {
            openBin("1");
        });

        compostBtn = findViewById(R.id.compost_btn);
        compostBtn.setOnClickListener(view -> {
            openBin("2");
        });

        paperBtn = findViewById(R.id.paper_btn);
        paperBtn.setOnClickListener(view -> {
            openBin("3");
        });

        recyclingBtn = findViewById(R.id.recycling_btn);
        recyclingBtn.setOnClickListener(view -> {
            openBin("4");
        });

        minusBtn = findViewById(R.id.minus_btn);
        minusBtn.setOnClickListener(view -> {
            if (quantity > 1) {
                quantity --;
                currentQ.setText(String.valueOf(quantity));
            }
        });

        plusBtn = findViewById(R.id.plus_btn);
        plusBtn.setOnClickListener(view -> {
            if (quantity < 10) {
                quantity ++;
                currentQ.setText(String.valueOf(quantity));
            }
        });
    }

    // Sends request to open a bin
    private void openBin(String type) {
        long time = date.getTime();

        JSONObject user = new JSONObject();
        try {
            user.put("username", username);
            user.put("quantity", quantity);
            user.put("timestamp", time);
        } catch (JSONException e) {
            Toast.makeText(getApplicationContext(), "A network error occurred.", Toast.LENGTH_LONG).show();
        }
        JsonObjectRequest jsonObjectRequestPost = new JsonObjectRequest(Request.Method.POST, TRASH_URL+type, user, r -> {
            switch (type) {
                case "1":
                    Toast.makeText(getApplicationContext(), "Garbage bin has been opened.", Toast.LENGTH_LONG).show();
                    break;
                case "2":
                    Toast.makeText(getApplicationContext(), "Compost bin has been opened.", Toast.LENGTH_LONG).show();
                    break;
                case "3":
                    Toast.makeText(getApplicationContext(), "Paper bin has been opened.", Toast.LENGTH_LONG).show();
                    break;
                default:
                    Toast.makeText(getApplicationContext(), "Plastic bin has been opened.", Toast.LENGTH_LONG).show();
                    break;
            }
            sendMessage();
        }, error -> {
            Toast.makeText(getApplicationContext(), "A network error occurred.", Toast.LENGTH_LONG).show();
        });
        queue.add(jsonObjectRequestPost);
    }

    // Send an Intent with an action named "custom-event-name". The Intent sent should
// be received by the ReceiverActivity.
    private void sendMessage() {
        Log.d("sender", "Broadcasting update");
        Intent intent = new Intent("newStats");
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
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
