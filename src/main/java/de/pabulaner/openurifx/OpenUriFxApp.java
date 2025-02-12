package de.pabulaner.openurifx;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.beans.property.SimpleStringProperty;
import javafx.beans.property.StringProperty;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

import java.awt.Desktop;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.CountDownLatch;

public class OpenUriFxApp extends Application {

    private static int receivedUri = 0;

    private static Timer timer = new Timer();

    private static StringProperty textProperty = new SimpleStringProperty("Calling command 'open openurifx://test123'...");

    public static void main(String[] args) {
        launch(args);
    }

    public static void registerJDKOpenUriHandler() {
        Desktop.getDesktop().setOpenURIHandler(e -> {
            Platform.runLater(() -> {
                receivedUri += 1;
                addMessage("Received: " + e.getURI());
            });
        });
    }

    public static void addMessage(String msg) {
        textProperty.setValue(textProperty.getValueSafe() + "\n" + msg);
    }

    @Override
    public void start(Stage stage) throws Exception {
        registerJDKOpenUriHandler();
        MenuBar menuBar = new MenuBar();

        Menu menu1 = new Menu("Menu 12");
        Menu menu2 = new Menu("Menu 2");

        MenuItem item1 = new MenuItem("Item 1");
        MenuItem item2 = new MenuItem("Item 2");
        MenuItem item3 = new MenuItem("Item 3");
        item1.setOnAction(event -> addMessage("Item 1 clicked"));

        menu1.getItems().addAll(item1, item2);
        menu2.getItems().addAll(item3);
        menuBar.getMenus().addAll(menu1, menu2);
        menuBar.setUseSystemMenuBar(true);

        BorderPane pane = new BorderPane();
        Label label = new Label();
        label.textProperty().bind(textProperty);
        pane.setTop(menuBar);
        pane.setCenter(label);
        Scene scene = new Scene(pane);
        stage.setScene(scene);
        stage.setHeight(300);
        stage.setWidth(600);
        stage.setTitle("JavaFX says hello");
        stage.show();

        Runtime.getRuntime().exec(new String[] {"open", "openurifx://test123"});

        timer.schedule(new TimerTask() {

            @Override
            public void run() {
                try {

                    FileWriter writer = new FileWriter("/tmp/openurifx-output.txt");
                    writer.write(String.valueOf(receivedUri));
                    writer.flush();
                    writer.close();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }

                Platform.runLater(() -> addMessage(receivedUri == 1
                        ? "Successful!"
                        : "Failure!"));
            }
        }, 3000);
    }
}
