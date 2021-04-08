package com.example.garbotapp;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.drawable.DrawableCompat;
import androidx.recyclerview.widget.RecyclerView;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class LoginActivity extends AppCompatActivity {
    private RequestQueue queue;
    private static final String LOGIN_URL = "http://e348951796ba.ngrok.io/user/";

    private EditText enterName;
    private EditText enterPass;
    private Button login;
    private Button createAccount;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        // Start by setting up a title for the page
        ActionBar actionBar = getSupportActionBar();
        if(actionBar != null) {
            String title = "Login";
            actionBar.setTitle(title);
        }

        queue = Volley.newRequestQueue(getApplicationContext());

        enterName = findViewById(R.id.enter_username);
        enterPass = findViewById(R.id.enter_password);
        login = findViewById(R.id.login);
        login.setOnClickListener(view -> {
            accountLogin();
        });
        createAccount = findViewById(R.id.create_account);
        createAccount.setOnClickListener(view -> {
            Intent createAccountIntent = new Intent(LoginActivity.this, CreateAccount.class);
            startActivity(createAccountIntent);
        });

    }

    private void accountLogin() {
        String enteredUsername = enterName.getText().toString().trim();
        String enteredPass = enterPass.getText().toString().trim();

        if (enteredUsername.equals("")) {
            Toast.makeText(getApplicationContext(), "Please enter your username.", Toast.LENGTH_LONG).show();
            return;
        } else if (enteredPass.equals("")) {
            Toast.makeText(getApplicationContext(), "Please enter your password.", Toast.LENGTH_LONG).show();
            return;
        }

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.GET, LOGIN_URL+enteredUsername, null, response -> {
            if (response.has("password")) {
                try {
                    String password = (String) response.get("password");

                    if(password.equals(enteredPass)) {
                        Toast.makeText(getApplicationContext(), "Welcome "+enteredUsername+"!", Toast.LENGTH_SHORT).show();
                        Intent mainIntent = new Intent(LoginActivity.this, MainActivity.class);
                        mainIntent.putExtra("USERNAME", enteredUsername);
                        startActivity(mainIntent);
                    } else {
                        Toast.makeText(getApplicationContext(), "Either entered username or password is incorrect.", Toast.LENGTH_SHORT).show();
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                Toast.makeText(getApplicationContext(), "Either entered username or password is incorrect.", Toast.LENGTH_SHORT).show();
            }
        }, error -> {
            Toast.makeText(getApplicationContext(), "A network error occurred.", Toast.LENGTH_SHORT).show();
        });
        queue.add(jsonObjectRequest);
    }
}
