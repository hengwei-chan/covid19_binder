is_seq_in_graph = True          # set True to use sequential data of proteins
is_con_in_graph = True          # set True to use contact map data
is_profile_in_graph = True
is_emb_in_graph = True          # set True to use embedding features from TAPE-proteins, False to use one-hot encoded data

NUM_EPOCHS = 2000               # Number of epochs for which the model is trained
TRAIN_BATCH_SIZE = 128          # Number of samples for one training batch
TEST_BATCH_SIZE = 256           # Number of samples for one testing batch
run_model = 0                   # 0 for GEFA, 1 for GLFA
cuda = 0                        # GPU used
setting = 0                     # Setting number, 0, 1, 2 or 3
LR = 0.0005                     # Learning Rate
dataset = 'davis'               # dataset used for training
to_plot_drug = True             # set True to plot graphs of drugs from smiles
to_plot_prot = False            # set True to plot graphs of proteins from smiles
mode = 0                        # 0 for training, 1 for evaluating trained model on test data, 2 for getting predictions on new data