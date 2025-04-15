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
import java.util.logging.FileHandler;
import java.util.logging.Logger;

public class OpenUriFxApp extends Application {

    private static final Logger LOGGER = Logger.getLogger(OpenUriFxApp.class.getName());

    static {
        try {
            LOGGER.addHandler(new FileHandler("/tmp/OpenUriFxApp-" + System.currentTimeMillis() + ".log"));
        } catch (IOException e) {
            LOGGER.severe(e.getMessage());
        }
    }

    private static String mode = null;

    private static boolean menu = false;

    private static int uri = 0;

    private static final StringProperty textProperty = new SimpleStringProperty("");

    public static void main(String[] args) {
        mode = System.getenv("APP_MODE");
        log("Mode: '" + mode + "'");

        if (mode.equals("before")) {
            registerHandler();
        }

        launch(args);
    }

    @Override
    public void start(Stage stage) throws Exception {
        if (mode.equals("after")) {
            registerHandler();
        }

        MenuBar menuBar = new MenuBar();

        Menu menu1 = new Menu("Menu 1");
        Menu menu2 = new Menu("Menu 2");

        MenuItem item1 = new MenuItem("Item 1");
        MenuItem item2 = new MenuItem("Item 2");
        MenuItem item3 = new MenuItem("Item 3");

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

        menu = menuBar.getHeight() < 0.1;

        writeStatus();
        log("Menu: " + menu);
    }

    private static void registerHandler() {
        Desktop.getDesktop().setOpenURIHandler(e -> {
            Platform.runLater(() -> {
                uri += 1;
                writeStatus();
                log("Uri: '" + e.getURI() + "'");
            });
        });
    }

    private static void writeStatus() {
        try (
                FileWriter writer = new FileWriter("/tmp/OpenUriFxApp-output.txt")
        ) {
            writer.write(String.format("menu: %b, uri: %d", menu, uri));
            writer.flush();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static void log(String msg) {
        LOGGER.info(msg);
        textProperty.setValue(textProperty.getValueSafe() + "\n" + msg);
    }
}
