package com.example.garbotapp;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Objects;

public class CreateAccount extends AppCompatActivity {
    private RequestQueue queue;
    private static String CREATE_URL = "http://e348951796ba.ngrok.io/user/";;

    private EditText enterName;
    private EditText enterPass;
    private EditText reenterPass;
    private Button createAccount;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_account);

        // Start by setting up a title for the page
        ActionBar actionBar = getSupportActionBar();
        if(actionBar != null) {
            String title = "New Account";
            actionBar.setTitle(title);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        queue = Volley.newRequestQueue(getApplicationContext());

        enterName = findViewById(R.id.enter_new_username);
        enterPass = findViewById(R.id.enter_new_password);
        reenterPass = findViewById(R.id.reenter_password);
        createAccount = findViewById(R.id.create_new_account);
        createAccount.setOnClickListener(view -> {
            createAccount();
        });
    }

    // Creates a new account for current user if the chosen username is not taken
    private void createAccount() {
        String enteredUsername = enterName.getText().toString().trim();
        String enteredPass = enterPass.getText().toString().trim();
        String reenteredPass = reenterPass.getText().toString().trim();

        if(!checkValid(enteredUsername, enteredPass, reenteredPass)) {
            return;
        }

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET, CREATE_URL+enteredUsername, null, response -> {
            if (response.has("password")) { // Username already exists in the database
                Toast.makeText(getApplicationContext(), "It seems like your selected username already exists!", Toast.LENGTH_SHORT).show();
            } else { // Username does not exist in the database
                JSONObject user = new JSONObject();
                try {
                    user.put("username", enteredUsername);
                    user.put("password", enteredPass);
                } catch (JSONException e) {
                    Toast.makeText(getApplicationContext(), "A network error occurred.", Toast.LENGTH_LONG).show();
                }
                JsonObjectRequest jsonObjectRequestPost = new JsonObjectRequest(Request.Method.POST, CREATE_URL, user, r -> {
                    Intent mainIntent = new Intent(CreateAccount.this, MainActivity.class);
                    mainIntent.putExtra("USERNAME", enteredUsername);
                    mainIntent.putExtra("URL", CREATE_URL);
                    startActivity(mainIntent);
                }, error -> {
                    Toast.makeText(getApplicationContext(), error.getMessage(), Toast.LENGTH_SHORT).show();
                    Log.d("Test", error.getMessage());
                    Toast.makeText(getApplicationContext(), "A network error occurred.", Toast.LENGTH_LONG).show();
                });
                queue.add(jsonObjectRequestPost);
            }
        }, error -> {
            Toast.makeText(getApplicationContext(), "A network error occurred.", Toast.LENGTH_SHORT).show();
        });
        queue.add(jsonObjectRequest);
    }

    // Checks if the inputs are valid for creating a new account
    private boolean checkValid(String enteredUsername, String enteredPass, String reenteredPass){
        if (enteredUsername.equals("")) {
            Toast.makeText(getApplicationContext(), "Please enter a username.", Toast.LENGTH_LONG).show();
            return false;
        } else if (enteredPass.equals("")) {
            Toast.makeText(getApplicationContext(), "Please enter a password.", Toast.LENGTH_LONG).show();
            return false;
        } else if (reenteredPass.equals("")) {
            Toast.makeText(getApplicationContext(), "Please reenter your password.", Toast.LENGTH_LONG).show();
            return false;
        } else if (!reenteredPass.equals(enteredPass)) {
            Toast.makeText(getApplicationContext(), "Your entered passwords do not match!", Toast.LENGTH_LONG).show();
            return false;
        } else if (enteredUsername.equals("1") || enteredUsername.equals("2") || enteredUsername.equals("3") || enteredUsername.equals("4")) {
                Toast.makeText(getApplicationContext(), "The selected username is not valid!", Toast.LENGTH_LONG).show();
                return false;
        } else {
            return true;
        }
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
